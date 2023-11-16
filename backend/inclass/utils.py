import math


def classes_needed(attended, total, needed_percentage):
    current_percentage = (attended / total) * 100

    if current_percentage >= needed_percentage:
        return 0  # No additional classes needed

    classes_required = (needed_percentage * total - attended * 100) / (
        100 - needed_percentage
    )

    return math.ceil(classes_required)
