--[[
This file is the registry for extended syscall allocations (driver syscalls).
Any developer can get an allocation by submitting a pull request, you do not need to have public
code in order to reserve an allocation for it. By having such an open policy, it becomes very easy
to prevent namespace clashes.

Every extended syscall namespace consists of the top three bytes of a uint32_t. The bottom byte is
used for the different syscalls within that namespace.
--]]

registry = {
------------------------------------------------------------------
["rocks.storm.simplegpio"]={
allocation=0x000001,
maintainer="Michael Andersen",
email="m.andersen@cs.berkeley.edu",
description=[[
A simple GPIO driver for the Storm.
]] },

------------------------------------------------------------------
}


