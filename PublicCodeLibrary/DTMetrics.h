/*!
 \file		DTMetrics.h
 \version	0.0.1
 \brief		Header file containing applicationwide constants like metrics, keys.
 \details	Mainly UI, REST backend and key value constants are included here.
 \attention Copyright 2010 Deutsche Telekom AG. All rights reserved.
 \author	Stefan Herold
 \date		2010-02-05
*/

#import <UIKit/UIKit.h>


// PDE alpha value for iPhone like devices (iPhone 2G, 3G, 3Gs, 4G)
#define DT_PDE_ALPHA_VALUE 56.0


static CGFloat const DT_UI_BASIC_MARGIN_HORIZONTAL                              = (int) (0.25		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_BASIC_MARGIN_VERTICAL								= (int) (0.25		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_ICON_WITH_TWO_LINED_CAPTION_CONTAINER_WIDTH			= (int) (1.5		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_WITH_TWO_LINED_CAPTION_CONTAINER_HEIGHT			= (int) (1.5		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_75_WIDTH										= (int) (0.75		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_75_HEIGHT										= (int) (0.75		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_100_WIDTH										= (int) (1.0		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_100_HEIGHT										= (int) (1.0		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_TITLE_VERTICAL_PADDING							= (int) (0.1		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_ICON_ROUND_CORNER_DEFAULT_SIZE						= (int) (2.0);
static CGFloat const DT_UI_ICON_ROUND_CORNER_SIZE								= (int) (0.05		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_GRID_VIEW_INTRA_TILE_PADDING							= (int) (0.1		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_GRID_VIEW_MARGIN_SIZE								= (int) (0.25		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_MULTI_LINE_HEADER_HEIGHT								= (int) (1.0		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_MULTI_LINE_HEADER_PADDING							= (int) (0.15		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_MULTI_LINE_SUB_HEADER_PADDING_HORIZONTAL				= (int) (0.25		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SINGLE_LINE_SUB_HEADER_HEIGHT						= (int) (0.5		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SINGLE_LINE_HEADER_HEIGHT							= (int) (0.66		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_SLIDER_RIGHT_CONTENT_PADDING							= (int) (0.15		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SLIDER_LABEL_AREA_HEIGHT								= (int) (0.40		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SLIDER_AREA_HEIGHT									= (int) (0.60		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SLIDER_KNOB_HEIGHT									= (int) (0.40		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SLIDER_HEIGHT										= (int) (0.15		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_SLIDER_ROUND_CORNER_SIZE								= (int) (0.03		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_PROGRESSBAR_HEIGHT									= (int) (0.15		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_TEXTFIELD_HEIGHT										= (int) (0.66		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_TEXTFIELD_PADDING									= (int) (0.15		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_BUTTON_HEIGHT										= 42.0f;
static CGFloat const DT_UI_BUTTON_PADDING										= (int) (0.15		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_HORIZONTAL_LINE_HEIGHT								= (int) (0.018		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_HORIZONTAL_LINE_PADDING								= (int) (0.15		* DT_PDE_ALPHA_VALUE);

static CGFloat const DT_UI_LABEL_PADDING										= (int) (0.15		* DT_PDE_ALPHA_VALUE) + 1;

static CGFloat const DT_UI_BUTTON_LEFT_CAP_WIDTH								= 20.0f;

static CGFloat const DT_UI_AD_PADDING											= (int) (0.179		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_AD_HEIGHT											= 50.0f;

static CGFloat const DT_UI_CHECKMARK_HEIGHT										= 30.0f;
static CGFloat const DT_UI_CHECKMARK_WIDTH										= 30.0f;

//
// Table Cell
//

static CGFloat const DT_UI_TABLECELL_HORIZONTAL_ELEMENT_MARGIN					= (int) (0.179		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_TABLECELL_VERTICAL_ELEMENT_MARGIN					= (int) (0.089		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_TABLECELL_KEY_TO_SUBKEY_RIGHT_HORIZONTAL_MARGIN		= (int) (0.089		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_TABLECELL_TITLE_TO_SUBTITLE_RIGHT_HORIZONTAL_MARGIN	= (int) (0.089		* DT_PDE_ALPHA_VALUE);
static CGFloat const DT_UI_TABLECELL_HEIGHT										= (int) (60);

static CGFloat const DT_UI_TABLECELL_ACCESSORY_VIEW_RIGHT_MARGIN				= 15.0;
static CGFloat const DT_UI_TABLECELL_ACCESSORY_VIEW_ARROW_WIDTH					= 4.5;
static CGFloat const DT_UI_TABLECELL_ACCESSORY_VIEW_ARROW_LINE_WIDTH			= 3.0;

#undef DT_PDE_ALPHA_VALUE