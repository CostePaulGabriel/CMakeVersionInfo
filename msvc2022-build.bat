@echo off
if not exist build mkdir build
cd build

echo Generating MSVC-Debug configuration...
cmake -DCMAKE_BUILD_TYPE=Debug -G "Visual Studio 17 2022" ..
cmake --build . --config Debug --parallel 4

echo Generating MSVC-Release configuration...
cmake -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 17 2022" ..
cmake --build . --config Release --parallel 4

echo Build process completed.
pause