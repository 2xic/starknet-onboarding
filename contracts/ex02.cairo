%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import (assert_le)

# We want to store more info than just the `star` size.
# We are going to give them a name and a size

# TODO
# Create a `Star` stuct
# It must have two members:
# - name
# - size
# Both members are of type `felt`
# https://www.cairo-lang.org/docs/reference/syntax.html#structs

struct Star:
    member name : felt
    member size : felt
end

@storage_var
func dust(address: felt) -> (amount: felt):
end

# TODO
# Update the `star` storage to store `Star` instead of `felt`
@storage_var
func star(address: felt, slot: felt ) -> (star : Star):
end


@storage_var
func slot(address: felt) -> (slot: felt):
end

@event
func a_star_is_born(account: felt, slot: felt, size: Star):
end

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

# TODO
# Update the `light_star` external so it take a `Star` struct instead of the amount of dust
# Caller `dust` storage must be deducted form a amount equal to the star size
@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _star: Star):
    let dust_amount = _star.size
    # TODO
    # Get the caller address
    # Get the address of the account that issued the call
    let (address) = get_caller_address()
    # Get the amount on dust owned by the caller
    let (current_amount) = dust.read(address)
    # Read the amount of dust this user own (it's read from the storage you have to create)    
    # Default value is 0 for all uninitialized keys
    # Make sure this amount is at least equal to `dust_amount`

    # ME: Okay, I guess this is the way we do if statments since cario does not seem to have <= operator ? 
    assert_le(dust_amount, current_amount)
    # Get the caller next available `slot`
    let (current_slot) = slot.read(address)

    # Update the amount of dust owned by the caller
    # ME : value is destroyed, so we have to reduce the amount.
    dust.write(address, current_amount - dust_amount)

    # Register the newly created star
    star.write(
        address,
        current_slot,
        _star
    )

    # Increment the caller next available slot
    slot.write(
        address,
        current_slot + 1
    )

    # Emit an `a_star_is_born` even with appropiate valued
    a_star_is_born.emit(
        address,
        current_slot,
        _star
    )

    return ()
end


@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

# TODO
# Create a view for `star`
# It must return an instance of `Star` instead of a `felt`
@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, slot: felt) -> (
        star: Star):
    let (res) = star.read(address, slot)
    return (res)
end


@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = slot.read(address)
    return (res)
end