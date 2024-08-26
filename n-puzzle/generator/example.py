from math import factorial

def permutation_index(state):
    """Returns the permutation index of the given state."""
    index = 0
    size = len(state)
    factorials = [factorial(i) for i in range(size)]

    for i in range(size):
        smaller_count = sum(1 for j in range(i + 1, size) if state[j] < state[i])
        index += smaller_count * factorials[size - i - 1]
    
    return index

# Example state (3x3 puzzle)
state = [1, 2, 3, 4, 5, 6, 7, 0, 8]
print(permutation_index(state))  # Outputs a unique integer

