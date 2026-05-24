/**
 * ConfigManager 实现
 */
#include "ConfigManager.h"

namespace tdlib {

ConfigManager& ConfigManager::instance() {
    static ConfigManager s_instance;
    return s_instance;
}

} // namespace tdlib
