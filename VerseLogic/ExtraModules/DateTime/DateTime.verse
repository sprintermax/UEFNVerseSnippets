# WIP DateTime is not yet implemented

# To keep module consistent with verse time definitions, most date values are represented
# as floats, where 0.0 is the start of the Unix Epoch (January 1, 1970 00:00.000000000 UTC).

# Verse Unix Timestamp Float Representation
#
#              0                   1
#              0 1 2 3 4 5 6 7 8 9 0 1 2
# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# |  S  |  .  |  M  |     N     |  ...  |
# +-+-+-+-+--++-+-+-+-+-+-+-+-+-+-+-+-+-+
# S:    Seconds part of the timestamp, can be multiple bytes long.
# .:    Decimal point separator of the seconds and fractional parts.
# M:    Miliseconds part of the timestamp, always 3 bytes long.
# N:    Nanoseconds part of the timestamp, always 6 bytes long.
# ...:  Extra precision floating point that may exist, usually ignored.