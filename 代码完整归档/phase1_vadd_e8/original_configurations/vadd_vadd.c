#include <klib.h>
#include <stdint.h>

static int64_t a[16] __attribute__((aligned(128))) = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
static int64_t b[16] __attribute__((aligned(128))) = {100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600};
static int64_t c[16] __attribute__((aligned(128)));

#define RDCSR(reg, dst) asm volatile("csrr %0, " #reg : "=&r"(dst) :: "memory")

int main() {
  uint64_t vl = 0, c0, c1, i0, i1;

  asm volatile ("li t0, 0x600\n\tcsrs mstatus, t0" ::: "t0", "memory");
  RDCSR(cycle, c0);  RDCSR(instret, i0);

  asm volatile (
    "vsetvli %0, %1, e64, m1, ta, ma\n\t"
    "vle64.v v1, (%2)\n\t"
    "vle64.v v2, (%3)\n\t"
    "vadd.vv v3, v1, v2\n\t"
    "vse64.v v3, (%4)\n\t"
    : "=&r"(vl)
    : "r"((uint64_t)8), "r"(a), "r"(b), "r"(c)
    : "memory"
  );

  RDCSR(cycle, c1);  RDCSR(instret, i1);

  printf("vl      = %d\n", (int)vl);
  printf("c       = %d %d\n", (int)c[0], (int)c[1]);
  printf("cycle   = %d -> %d  (%d)\n", (int)c0, (int)c1, (int)(c1 - c0));
  printf("instret = %d -> %d  (%d)\n", (int)i0, (int)i1, (int)(i1 - i0));
  int ok = (c[0] == 101 && c[1] == 202);
  printf("%s\n", ok ? "VADD PASS" : "VADD FAIL");
  return ok ? 0 : 1;
}
