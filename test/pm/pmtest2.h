#ifndef __PMTEST2_H_
#define __PMTEST2_H_

#include <os2.h>

#define ID_PMTEST2      100
#define WC_PMTEST2      "PMTEST2"

#define ID_M_FILE       200
#define ID_MI_NEW       ( ID_M_FILE + 1 )
#define ID_MI_OPEN      ( ID_M_FILE + 2 )
#define ID_MI_SAVE      ( ID_M_FILE + 3 )
#define ID_MI_SAVEAS    ( ID_M_FILE + 4 )
#define ID_MI_EXIT      ( ID_M_FILE + 5 )

#define ID_M_EDIT       300
#define ID_MI_UNDO      ( ID_M_EDIT + 1 )
#define ID_MI_REDO      ( ID_M_EDIT + 2 )
#define ID_MI_CUT       ( ID_M_EDIT + 3 )
#define ID_MI_COPY      ( ID_M_EDIT + 4 )
#define ID_MI_PASTE     ( ID_M_EDIT + 5 )
#define ID_MI_CLEAR     ( ID_M_EDIT + 6 )


typedef struct
{
    HAB     habAnchor;
    HWND    hwndFrame;
    HWND    hwndMenu;
} INSTDATA, *PINSTDATA;

#endif
