extends Node

var unlocked_research: Array[String] = []

func unlock(research_id: String) -> void:
	if research_id in unlocked_research:
		return

	unlocked_research.append(research_id)

func is_unlocked(research_id: String) -> bool:
	return research_id in unlocked_research
