extends Node

const DIAMONDS = "diamonds"
const CLUBS = "clubs"
const HEARTS = "hearts"
const SPADES = "spades"

const SUITS=[DIAMONDS,CLUBS,HEARTS,SPADES]
const RED_SUITS=[HEARTS,DIAMONDS]
const BLACK_SUITS=[CLUBS,SPADES]
const POINTS=['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
const SUIT_SYMBOLS = {
	DIAMONDS:"♦",
	CLUBS:"♣",
	HEARTS:"♥",
	SPADES:"♠"
}

func generate_deck()->Array[ClassCardStack]:
	var deck:Array[ClassCardStack]=[]
	for suit in SUITS:
		var cards:ClassCardStack=ClassCardStack.new()
		var cards_tmp:Array[ClassCard] =[]
		for point in POINTS:
			cards_tmp.append(ClassCard.new(suit,point))
		cards.push_n(cards_tmp)
		deck.append(cards)
	return deck
	

func get_suit_symbol(suit:String)->String:
	return SUIT_SYMBOLS.get(suit)

func is_red_suit(suit:String)->bool:
	return suit in RED_SUITS

func is_black_suit(suit:String)->bool:
	return suit in BLACK_SUITS

func is_opposite_suits(suit_1:String,suit_2:String):
	return ((is_red_suit(suit_1) and is_black_suit(suit_2))
			or (is_black_suit(suit_1) and is_red_suit(suit_2)))

func get_point_num_value(point:String)->int:
	var index = POINTS.find(point)
	if -1==index:
		return -1
	return  index+1
