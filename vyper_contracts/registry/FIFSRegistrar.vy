import ENSRegistry as Registry

registry: Registry
rootNode: bytes32

@external
def __init__(ensAddr: address, node: bytes32):
    self.registry = Registry(ensAddr)
    self.rootNode = node

@external
def register(label: bytes32, owner: address):
    currentOwner: address = self.registry.owner(keccak256(_abi_encode(self.rootNode, label)))
    assert currentOwner == empty(address) or currentOwner == msg.sender
    self.registry.setSubnodeOwner(self.rootNode, label, owner)
