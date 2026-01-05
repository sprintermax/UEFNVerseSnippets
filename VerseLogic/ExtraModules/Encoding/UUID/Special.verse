# The Nil UUID is special form of UUID that is specified to have all 128 bits set to zero.
# A Nil UUID value can be useful to communicate the absence of any other UUID value in situations
# that otherwise require or use a 128-bit UUID. A Nil UUID can express the concept "no such value here".
# Thus, it is reserved for such use as needed for implementation-specific situations.
#
# 00000000-0000-0000-0000-000000000000



# The Max UUID is a special form of UUID that is specified to have all 128 bits set to 1.
# A Max UUID value can be used as a sentinel value in situations where a 128-bit UUID is required,
# but a concept such as "end of UUID list" needs to be expressed and is reserved for such use
# as needed for implementation-specific situations.
#
# FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF