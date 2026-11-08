#include <klib.h>
#include <stdint.h>

static int8_t a[8] __attribute__((aligned(128))) = {
  -1, 2, -3, 4, 127, -128, 100, 50
};
static int8_t b[8] __attribute__((aligned(128))) = {
  1, -2, 3, 4, 1, -1, 27, -100
};
static int8_t c[8] __attribute__((aligned(128)));
static const int8_t expected[8] = {
  0, 0, 0, 8, -128, 127, 127, -50
};

int main(void) {
  uint64_t vl = 0;
  const uint64_t avl = 8;

  asm volatile ("li t0, 0x600\n\tcsrs mstatus, t0" ::: "t0", "memory");

  asm volatile (
    "vsetvli %0, %1, e8, m1, ta, ma\n\t"
    "vle8.v v1, (%2)\n\t"
    "vle8.v v2, (%3)\n\t"
    "vadd.vv v3, v1, v2\n\t"
    "vse8.v v3, (%4)\n\t"
    : "=&r"(vl)
    : "r"(avl), "r"(a), "r"(b), "r"(c)
    : "memory"
  );

  printf("SEW=e8 vl=%d\n", (int)vl);
  printf("vadd result:");
  for (int i = 0; i < 8; ++i) {
    printf(" %d", (int)c[i]);
  }
  printf("\n");

  int ok = (vl == 8);
  for (int i = 0; i < 8; ++i) {
    ok = ok && (c[i] == expected[i]);
  }
  printf("%s\n", ok ? "VADD E8 PASS" : "VADD E8 FAIL");
  return ok ? 0 : 1;
}
