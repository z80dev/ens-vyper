import ENSRegistry as Registry

registry: Registry
rootNode: bytes32

@external
def __init__(ensAddr: address, node: bytes32):
    self.registry = Registry(ensAddr)
    self.rootNode = node

@external
def register(label: bytes32, owner: address):
    self._checkAuth(label)
    self.registry.setSubnodeOwner(self.rootNode, label, owner)


@internal
def _checkAuth(label: bytes32):
    owner: address = self.registry.owner(keccak256(_abi_encode(self.rootNode, label)))
    assert owner == empty(address) or owner == msg.sender
