#include <string>
using namespace std;

constexpr uint64_t hash_str(const char* s, size_t index = 0) {
  return s + index == nullptr || s[index] == '\0' ? 55 : hash_str(s, index + 1) * 33 + (unsigned char)(s[index]);
}
