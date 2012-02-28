/**
 * @param {number} x Position on X axis
 * @param {number} z Position on Z axis
 * @param {number} t Time in seconds
 * @return {number} Position on Y axis
 */
function formula(x, z, t)
{
    var e;
    
    x = Number(x);
    z = Number(z);
    t = Number(t);
    
    return Math.sin((e = Math.sqrt(x * x + z * z) * 3) - 2 * t) / (e + 0.3);
}