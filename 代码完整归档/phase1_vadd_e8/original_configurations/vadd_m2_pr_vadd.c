#include <klib.h>
#include <stdint.h>
static int64_t a[16] __attribute__((aligned(128))) = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
static int64_t b[16] __attribute__((aligned(128))) = {100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600};
static int64_t c[16] __attribute__((aligned(128)));
int main() {
  uint64_t vl = 0;
  asm volatile ("li t0, 0x600\n\tcsrs mstatus, t0" ::: "t0", "memory");
  asm volatile (
    "vsetvli %0, %1, e64, m2, ta, ma\n\t"
    "vle64.v v2, (%2)\n\t"
    "vle64.v v4, (%3)\n\t"
    "vadd.vv v6, v2, v4\n\t"
    "vse64.v v6, (%4)\n\t"
    : "=&r"(vl) : "r"((uint64_t)8), "r"(a), "r"(b), "r"(c) : "memory");
  printf("vl=%d c=%d\\n", (int)vl, (int)c[0]);
  return (int)(c[0] - 101);
}
