value: uint256

@external
def setValue(val: uint256):
    self.value = val

@external
@view
def getValue() -> uint256:
    return self.value
