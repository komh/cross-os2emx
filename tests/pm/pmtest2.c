#define INCL_NLS
#define INCL_WIN
#include <os2.h>
#include <stdio.h>
#include <stdlib.h>

#include "pmtest2.h"

MRESULT EXPENTRY windowProc( HWND hwnd, ULONG msg, MPARAM mp1, MPARAM mp2 )
{
    PINSTDATA pid;

    pid = ( PINSTDATA ) WinQueryWindowPtr( hwnd, 0 );

    switch( msg )
    {
        case WM_CREATE :
            pid = ( PINSTDATA )malloc( sizeof( INSTDATA ));

            WinSetWindowPtr( hwnd, 0, pid );

            pid->habAnchor = WinQueryAnchorBlock( hwnd );
            pid->hwndFrame = WinQueryWindow( hwnd, QW_PARENT );
            pid->hwndMenu = WinWindowFromID( pid->hwndFrame, FID_MENU );
            break;

        case WM_DESTROY :
            free( pid );
            break;

        case WM_INITMENU :
            switch( SHORT1FROMMP( mp1 ))
            {
                case ID_M_FILE :
                {
                    MENUITEM mi;

                    WinSendMsg( pid->hwndMenu,
                                MM_QUERYITEM,
                                MPFROM2SHORT( ID_M_FILE, TRUE ),
                                MPFROMP( &mi ));

                    WinSendMsg( mi.hwndSubMenu,
                                MM_SETITEMTEXT,
                                MPFROMSHORT( ID_MI_EXIT ),
                                MPFROMP( "Exit?\tAlt-F4" ));

                    break;
                }

                default :
                    return WinDefWindowProc( hwnd, msg, mp1, mp2 );
            }
            break;

        case WM_PAINT :
        {
            HPS hps;
            RECTL rcl;

            hps = WinBeginPaint( hwnd, NULLHANDLE, &rcl);

            WinFillRect( hps, &rcl, SYSCLR_WINDOW );

            WinQueryWindowRect( hwnd, &rcl );

            WinDrawText(
                hps,
                -1,
                "This my second PM program !!!",
                &rcl,
                CLR_BLACK,
                0,
                DT_CENTER | DT_VCENTER
            );

            WinEndPaint( hps );

            break;
        }

        case WM_CHAR :
        {
            USHORT  fsFlags = SHORT1FROMMP( mp1 );
            UCHAR   ucRepeat = CHAR3FROMMP( mp1 );
            UCHAR   ucScancode = CHAR4FROMMP( mp1 );
            USHORT  usCh = SHORT1FROMMP( mp2 );
            USHORT  usVk = SHORT2FROMMP( mp2 );

            printf( "fl:%04X rp:%04X sc:%04X ch:%04X vk:%04X\n",
                    fsFlags, ucRepeat, ucScancode, usCh, usVk );
        }


        default :
            return WinDefWindowProc( hwnd, msg, mp1, mp2 );
    }

    return MRFROMSHORT( FALSE );
}

INT main( VOID )
{
    HAB hab;
    HMQ hmq;
    ULONG flFrameFlags;
    HWND hwndFrame;
    HWND hwndClient;
    QMSG qm;

    hab = WinInitialize( 0 );
    hmq = WinCreateMsgQueue( hab, 0);

    WinRegisterClass(
        hab,
        WC_PMTEST2,
        windowProc,
        CS_SIZEREDRAW,
        sizeof( PVOID )
    );

    flFrameFlags = FCF_SYSMENU | FCF_TITLEBAR | FCF_MINMAX | FCF_MENU |
                   FCF_SIZEBORDER | FCF_SHELLPOSITION | FCF_TASKLIST;

    hwndFrame = WinCreateStdWindow(
                    HWND_DESKTOP,               // parent window handle
                    WS_VISIBLE,                 // frame window style
                    &flFrameFlags,              // window style
                    WC_PMTEST2,                 // class name
                    "PM Test2",                 // window title
                    0L,                         // default client style
                    NULLHANDLE,                 // resource in exe file
                    ID_PMTEST2,                 // frame window id
                    &hwndClient                 // client window handle
                );

    if( hwndFrame != NULLHANDLE )
    {
        while( WinGetMsg( hab, &qm, NULLHANDLE, 0, 0 ))
            WinDispatchMsg( hab, &qm );

        WinDestroyWindow( hwndFrame );
    }

    WinDestroyMsgQueue( hmq );
    WinTerminate( hab );

    return 0;
}



