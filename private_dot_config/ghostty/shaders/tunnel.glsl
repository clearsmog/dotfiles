#define g(p,s) abs(dot(sin(p*s),cos(p*s).zxwy)-1.)/s

void mainImage(out vec4 O, vec2 C) {
  float i, d, z, s, T = iTime;
  vec4 o, q, p, U = vec4(2, 1, 0, 3);

  for (
    vec2 r = iResolution.xy;
    ++i < 79.;
    z += d + 5e-4,
    q = vec4(normalize(vec3(C - .5 * r, r.y)) * z, .2),
    q.z += T / 30.,
    q.y = abs(s = q.y + .1),
    p = q,
    p.y -= .11,
    p.xy *= mat2(cos(11. * U.zywz - 2. * p.z)),
    p.y -= .2,
    d = abs(g(p, 8.) - g(p, 24.)) / 4.,
    p = 1. + cos(.7 * U + 5. * q.z)
  )
    o += (s > 0. ? 1. : .1) * p.w * p / max(s > 0. ? d : d * d * d, 5e-4);

  o += (1.4 + sin(T) * sin(1.7 * T) * sin(2.3 * T)) * 1e3 * U / length(q.xy);

  O = tanh(o / 1e5);
}