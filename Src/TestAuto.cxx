#include <map>
#include <utility>

int main (void)
{
  std::map<int, int> mi;
  mi.insert(std::make_pair(5, 5));

  auto i = mi.find(5);
  return 0;
}
