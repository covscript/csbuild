#include <covscript/dll.hpp>
#include <covscript/cni.hpp>

CNI_ROOT_NAMESPACE {
	CNI_V(test, [](int a) { return a + 2; })
}
