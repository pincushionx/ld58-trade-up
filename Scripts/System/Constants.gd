extends Node

class_name Constants

const CARD_SIZE : Vector2 = Vector2(192, 192)
const NUM_SUITS : int = 4

enum PlayMode {
	PLAY = 0x00,
	
	# Paused
	PAUSED_MENU = 0x01,
	PAUSED_ANIMATION = 0x02,
	PAUSED_PLACEMENT = 0x04,
	
	# Popups
	DISCARD_POPUP = 0x10,
	WIN_POPUP = 0x20,
	LOSE_POPUP = 0x40,
	TUTORIAL_POPUP = 0x80,
	MODAL_POPUP = 0xF0,

	# Any reason to pause
	GAMEPLAY_PAUSED = 0xFF,
}

enum LAYER_MASK {
	DEFAULT = 0x01,
	ANY = 0xFFFF
}

enum SUIT {
	HEARTS,
	DIAMONDS,
	SPADES,
	CLUBS
}


enum CARD_RULES {

}

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD,
	VERY_HARD
}
