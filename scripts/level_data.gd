class_name LevelData
extends RefCounted

static var levels: Array = [
	{
		"id": 1,
		"name": "Level 1: Farm Cows",
		"image_path": "res://assets/images/level1.jpg",
		"grid_cols": 5,
		"grid_rows": 5,
		"cell_size": 120.0,
		"pieces": [
			# Piece 1: I-pentomino (vertical line of 5)
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(0, 1),
					Vector2i(0, 2),
					Vector2i(0, 3),
					Vector2i(0, 4)
				],
				"solved_grid_pos": Vector2i(0, 0)
			},
			# Piece 2: L-like shape
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(3, 1)
				],
				"solved_grid_pos": Vector2i(1, 0)
			},
			# Piece 3: T/P-pentomino variant
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1)
				],
				"solved_grid_pos": Vector2i(1, 1)
			},
			# Piece 4: U-pentomino variant
			{
				"cells": [
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(2, 1),
					Vector2i(1, 1),
					Vector2i(0, 1)
				],
				"solved_grid_pos": Vector2i(2, 2)
			},
			# Piece 5: J-pentomino
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1),
					Vector2i(3, 1)
				],
				"solved_grid_pos": Vector2i(1, 3)
			}
		]
	},
	{
		"id": 2,
		"name": "Level 2: Sunny Sheep",
		"image_path": "res://assets/images/level2.jpg",
		"grid_cols": 6,
		"grid_rows": 6,
		"cell_size": 110.0,
		"pieces": [
			# Piece 1: Vertical line of 6 (I-hexomino)
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(0, 1),
					Vector2i(0, 2),
					Vector2i(0, 3),
					Vector2i(0, 4),
					Vector2i(0, 5)
				],
				"solved_grid_pos": Vector2i(0, 0)
			},
			# Piece 2: L-like hexomino
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(4, 0),
					Vector2i(4, 1)
				],
				"solved_grid_pos": Vector2i(1, 0)
			},
			# Piece 3: P-hexomino variant
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(0, 1),
					Vector2i(1, 1)
				],
				"solved_grid_pos": Vector2i(1, 1)
			},
			# Piece 4: 3x2 Rectangular block (O-hexomino)
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1)
				],
				"solved_grid_pos": Vector2i(3, 2)
			},
			# Piece 5: S-hexomino variant
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1),
					Vector2i(0, 2)
				],
				"solved_grid_pos": Vector2i(1, 3)
			},
			# Piece 6: Z-hexomino variant
			{
				"cells": [
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1),
					Vector2i(3, 1)
				],
				"solved_grid_pos": Vector2i(2, 4)
			}
		]
	},
	{
		"id": 3,
		"name": "Level 3: Barn Chickens",
		"image_path": "res://assets/images/level3.jpg",
		"grid_cols": 5,
		"grid_rows": 5,
		"cell_size": 120.0,
		"pieces": [
			# Piece 1: L-shape pentomino
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(0, 1),
					Vector2i(0, 2),
					Vector2i(1, 2),
					Vector2i(2, 2)
				],
				"solved_grid_pos": Vector2i(0, 0)
			},
			# Piece 2: P-shape pentomino
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1)
				],
				"solved_grid_pos": Vector2i(1, 0)
			},
			# Piece 3: Stair block variant
			{
				"cells": [
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(3, 0)
			},
			# Piece 4: U-like variant
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(0, 1),
					Vector2i(1, 0),
					Vector2i(1, 1),
					Vector2i(2, 0)
				],
				"solved_grid_pos": Vector2i(0, 3)
			},
			# Piece 5: T-like variant
			{
				"cells": [
					Vector2i(0, 1),
					Vector2i(1, 0),
					Vector2i(1, 1),
					Vector2i(2, 0),
					Vector2i(2, 1)
				],
				"solved_grid_pos": Vector2i(2, 3)
			}
		]
	},
	{
		"id": 4,
		"name": "Level 4: Forest Friends",
		"image_path": "res://assets/images/level4.jpg",
		"grid_cols": 6,
		"grid_rows": 6,
		"cell_size": 110.0,
		"pieces": [
			# Piece 1: 3x2 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1)
				],
				"solved_grid_pos": Vector2i(0, 0)
			},
			# Piece 2: 3x2 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1)
				],
				"solved_grid_pos": Vector2i(3, 0)
			},
			# Piece 3: 2x3 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(0, 2)
			},
			# Piece 4: 3x2 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1)
				],
				"solved_grid_pos": Vector2i(2, 2)
			},
			# Piece 5: L-hexomino
			{
				"cells": [
					Vector2i(3, 0),
					Vector2i(3, 1),
					Vector2i(3, 2),
					Vector2i(2, 2),
					Vector2i(1, 2),
					Vector2i(0, 2)
				],
				"solved_grid_pos": Vector2i(2, 2)
			},
			# Piece 6: 1x6 Line
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(4, 0),
					Vector2i(5, 0)
				],
				"solved_grid_pos": Vector2i(0, 5)
			}
		]
	},
	{
		"id": 5,
		"name": "Level 5: Golden Fields",
		"image_path": "res://assets/images/level5.jpg",
		"grid_cols": 6,
		"grid_rows": 6,
		"cell_size": 110.0,
		"pieces": [
			# Piece 1: 2x3 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(0, 0)
			},
			# Piece 2: T-block variant
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(2, 1),
					Vector2i(3, 1)
				],
				"solved_grid_pos": Vector2i(2, 0)
			},
			# Piece 3: 2x3 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(2, 1)
			},
			# Piece 4: 2x3 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(0, 3)
			},
			# Piece 5: 2x3 Rect
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(0, 2),
					Vector2i(1, 2)
				],
				"solved_grid_pos": Vector2i(4, 2)
			},
			# Piece 6: L-shape hexomino
			{
				"cells": [
					Vector2i(0, 0),
					Vector2i(1, 0),
					Vector2i(0, 1),
					Vector2i(1, 1),
					Vector2i(2, 1),
					Vector2i(3, 1)
				],
				"solved_grid_pos": Vector2i(2, 4)
			}
		]
	}
]
