%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
)

from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.token.erc721.library import ERC721
from starkware.cairo.common.math import split_felt

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, symbol : felt
):
    ERC721.initializer(name, symbol)
    ERC721Enumerable.initializer()
    last_token_id.write(Uint256(0, 0))
    return ()
end

@storage_var
func last_token_id() -> (token_id : Uint256):
end

struct Animal:
    member sex : felt
    member legs : felt
    member wings : felt
end

@storage_var
func animal_by_token_id(token_id : Uint256) -> (animal : Animal):
end

#
# Getters
#

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(owner : felt) -> (
    balance : Uint256
):
    let (balance : Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (owner : felt):
    let (owner : felt) = ERC721.owner_of(token_id)
    return (owner)
end

@view
func getApproved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_id : Uint256
) -> (approved : felt):
    let (approved : felt) = ERC721.get_approved(token_id)
    return (approved)
end

@view
func isApprovedForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, operator : felt
) -> (is_approved : felt):
    let (is_approved : felt) = ERC721.is_approved_for_all(owner, operator)
    return (is_approved)
end

#
# Externals
#

@external
func approve{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    to : felt, token_id : Uint256
):
    ERC721.approve(to, token_id)
    return ()
end

@external
func setApprovalForAll{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    operator : felt, approved : felt
):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256
):
    ERC721Enumerable.transfer_from(_from, to, token_id)
    return ()
end

@external
func safeTransferFrom{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    _from : felt, to : felt, token_id : Uint256, data_len : felt, data : felt*
):
    ERC721Enumerable.safe_transfer_from(_from, to, token_id, data_len, data)
    return ()
end

# implementing interface IExerciseSolution

# func is_breeder(account : felt) -> (is_approved : felt):
# end

# func registration_price() -> (price : Uint256):
# end

# func register_me_as_breeder() -> (is_added : felt):
# end

@external
func declare_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    sex : felt, legs : felt, wings : felt
) -> (token_id : Uint256):
    alloc_locals

    let one : Uint256 = Uint256(1, 0)

    let last_id : Uint256 = last_token_id.read()
    let (new_token_id, _) = uint256_add(last_id, one)
    let (sender_address) = get_caller_address()

    ERC721Enumerable._mint(sender_address, new_token_id)

    last_token_id.write(new_token_id)
    animal_by_token_id.write(new_token_id, Animal(sex=sex, legs=legs, wings=wings))
    return (new_token_id)
end

@view
func get_animal_characteristics{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256
) -> (sex : felt, legs : felt, wings : felt):
    let (a) = animal_by_token_id.read(token_id)
    return (a.sex, a.legs, a.wings)
end

@view
func token_of_owner_by_index{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    account : felt, index : felt
) -> (token_id : Uint256):
    let i : Uint256 = _felt_to_uint256(index)
    let (res) = ERC721Enumerable.token_of_owner_by_index(account, i)
    return (res)
end

@external
func declare_dead_animal{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    token_id : Uint256
):
    ERC721Enumerable._burn(token_id)
    animal_by_token_id.write(token_id, Animal(sex=0, legs=0, wings=0))
    return ()
end

# private methods

func _felt_to_uint256{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}(
    felt_value : felt
) -> (uint256_value : Uint256):
    let (h, l) = split_felt(felt_value)
    return (Uint256(l, h))
end