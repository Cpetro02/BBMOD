#if XGLSL
#define MUL(m, v) ((m) * (v))
#define IVec4 ivec4
#else
#define MUL(m, v) mul(v, m)
#define IVec4 int4
#endif
