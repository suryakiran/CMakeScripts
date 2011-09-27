#include <memory>

int main ()
{
  std::unique_ptr<int> i (new int(5));
  return 0;
}
