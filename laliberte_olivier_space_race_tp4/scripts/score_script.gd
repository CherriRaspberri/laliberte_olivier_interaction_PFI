extends Label

#updates the score
func update_score(value: int):
	#fetches current score
	var score = int(text)
	#updates score value
	score += value
	#displays the updated score
	text = str(score)
