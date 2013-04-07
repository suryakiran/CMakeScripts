#include <iostream>
#include <vector>
#include <map>

int main (void)
{
  std::vector<int> vi;
  vi.push_back(10);
  vi.push_back(20);
  vi.push_back(30);
  vi.push_back(40);
  vi.push_back(50);

  for(int i: vi)
  {
    std::cout << i << std::endl;
  }

  std::map<int, std::string> m;
  m[1] = "One";
  m[2] = "Two";
  m[3] = "Three";

  for (auto i: m)
  {
    std::cout << i.first << '\t' << i.second << std::endl;
  }
}
