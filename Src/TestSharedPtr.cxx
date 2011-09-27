#include <memory>

int main ()
{
  std::shared_ptr<int> i (new int(5));
  return 0;
}
