#include <iostream>
#include <algorithm>
#include <vector>

int main (void)
{
  std::vector<int> vi;
  vi.push_back (10);
  vi.push_back (20);
  vi.push_back (30);
  vi.push_back (40);
  vi.push_back (50);

  std::for_each(vi.begin(), vi.end(), 
      [](int i) 
      { 
        std::cout << i << std::endl; 
      });

  return 0;
}
