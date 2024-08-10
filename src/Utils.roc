module [isApproxEq0, clampAngle]

isApproxEq0 : F64 -> Bool
isApproxEq0 = \x -> Num.isApproxEq x 0 {}

clampAngle : F64 -> F64
clampAngle = \angle ->
    if angle > Num.pi then
        clampAngle (angle - 2 * Num.pi)
    else if angle < (-Num.pi) then
        clampAngle (angle + 2 * Num.pi)
    else
        angle
