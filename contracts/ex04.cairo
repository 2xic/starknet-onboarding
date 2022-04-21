%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le
from starkware.cairo.common.bitwise import bitwise_xor
from starkware.cairo.common.alloc import alloc

struct Star:
    member name : felt
    member size : felt
end

@storage_var
func dust(address: felt) -> (amount: felt):
end

@storage_var
func star(address: felt, slot: felt) -> (star: Star):
end

@storage_var
func slot(address: felt) -> (slot: felt):
end

# This storage keep the count of addresses ranks
# 0 for human
# 1 for `Start Creator`
# 2 for `Stellar System Engineer` 
# 3 for `Great Architect of the Universe`
@storage_var
func rank(address: felt) -> (slot: felt):
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

@external
func light_stars{syscall_ptr : felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        stars_len: felt,
        stars: Star*):
    
    let (address) = get_caller_address()

    batch_create_stars(address, stars_len, stars)

    return ()
end

func batch_create_stars{syscall_ptr : felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, array_len: felt, array: Star*):
    if array_len == 0:
        return ()
    end

    insert_star(address, [array])
    batch_create_stars(address=address, array_len=array_len - 1, array=&array[1])
    
    return ()
end

func insert_star{syscall_ptr : felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt, new_star: Star):
    alloc_locals

    let (dust_reserve) = dust.read(address)
    assert_le(new_star.size, dust_reserve)

    dust.write(address, dust_reserve - new_star.size)

    let (local current_slot) = slot.read(address)
    
    star.write(address, current_slot, new_star)
    
    slot.write(address, current_slot + 1)
    # TODO
    # If the new user slot is equal to 1, 10 or 100, increment the caller rank
    # You will be confronted to revoked referenced
    # https://www.cairo-lang.org/docs/how_cairo_workcurrent_slots/consts.html#revoked-references
    # That's one of the most tricky feature of cairo. Treat yourself !
    let (results1) = bitwise_xor(current_slot, 1) 
    let (results2) = bitwise_xor(current_slot, 10) 
    let (results3) = bitwise_xor(current_slot, 100) 

    let (local array_x : felt*) = alloc()
    assert array_x[0] = results1
    assert array_x[1] = results2
    assert array_x[2] = results3
    let (computedvalue) = has_zero(array_x, 3)

    if computedvalue == 1:
        increase_rank(address)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else: 
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    
    a_star_is_born.emit(address, current_slot, new_star)
    
    return ()
end

func has_zero(arr: felt*, size: felt) -> (number) :
    if size == 0:
        return (0)
    end
    if [arr] == 0:
        return (1)
    end
    return has_zero(arr + 1, size - 1)
end

func increase_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt):
    let (current_rank) = rank.read(address)
    rank.write(address, current_rank + 1) 
    
    return ()
end

@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = dust.read(address)
    return (res)
end

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

# A view to the `rank` storage
@view
func view_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (
        amount: felt):
    let (res) = rank.read(address)
    return (res)
end