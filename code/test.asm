#include＜resource.h＞

#define ICO_MAIN 1000
#define DLG_MAIN 1000
#define IDC_INFO 1001
#define IDM_MAIN 2000
#define IDM_OPEN 2001
#define IDM_EXIT 2002

 #define IDM_1 4000
 #define IDM_2 4001
 #define IDM_3 4002
 #define IDM_4 4003


 ICO_MAIN ICON"main.ico"

 DLG_MAIN DIALOG 50,50,544,399
 STYLE DS_MODALFRAME|WS_POPUP|WS_VISIBLE|WS_CAPTION|WS_SYSMENU
 CAPTION"PE文件基本信息by qixiaorui"
 MENU IDM_MAIN
 FONT 9,"宋体"
 BEGIN
 CONTROL"",IDC_INFO,"RichEdit20A",196|ES_WANTRETURN|WS_CHILD|WS_READONLY
 |WS_VISIBLE|WS_BORDER|WS_VSCROLL|WS_TABSTOP,0,0,540,396
 END

 IDM_MAIN menu discardable
 BEGIN
 POPUP"文件(＆F)"
 BEGIN
 menuitem"打开文件(＆O)...",IDM_OPEN
 menuitem separator
 menuitem"退出(＆x)",IDM_EXIT
 END

 POPUP "查看"
 BEGIN
 menuitem "源文件",IDM_1
 menuitem "窗口透明度",IDM_2
 menuitem separator
 menuitem "大小",IDM_3
 menuitem "宽度",IDM_4
 END

 END