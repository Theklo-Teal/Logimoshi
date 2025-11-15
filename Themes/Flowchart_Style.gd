extends Resource
class_name FlowchartStyle

@export_color_no_alpha var backdrop := Color("3c3c3c")
@export_color_no_alpha var grid_color := Color("5d5d5d")
@export_color_no_alpha var axis_color := Color("914f48")
@export_group("Wire Colours", "wire_")
@export_color_no_alpha var wire_hiz_color := Color.CORNSILK
@export_color_no_alpha var wire_high_color := Color.DARK_KHAKI
@export_color_no_alpha var wire_low_color := Color.KHAKI
@export_color_no_alpha var wire_bus_color := Color.CORAL
@export_group("")
@export var nominal_cell_size : int = 60  ## Nominal grid cell size in pixels, when zoom is 100%
@export var nominal_thickness : int = 4   ## How thick are the grid lines
@export var pattern : PATT = PATT.SQUARE

enum PATT{
	SQUARE,
	DOTTED,
	ISO_DOTTED,
	TRI_VERT,
	TRI_HORZ,
}
enum {
	SQUARE,
	DOTTED,
	ISO_DOTTED,
	TRI_VERT,
	TRI_HORZ,
}
