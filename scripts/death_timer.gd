extends Timer

func ready() -> void:
	self.timeout.connect(Callable(get_parent(), "death_reset"))
