/**
 * 配置管理
 */
#pragma once

#include <string>

namespace tdlib {

class ConfigManager {
public:
    static ConfigManager& instance();

    void setApiId(int apiId) { apiId_ = apiId; }
    int getApiId() const { return apiId_; }

    void setApiHash(const std::string& hash) { apiHash_ = hash; }
    const std::string& getApiHash() const { return apiHash_; }

    void setDatabasePath(const std::string& path) { databasePath_ = path; }
    const std::string& getDatabasePath() const { return databasePath_; }

    ConfigManager(const ConfigManager&) = delete;
    ConfigManager& operator=(const ConfigManager&) = delete;

private:
    ConfigManager() = default;
    ~ConfigManager() = default;

    int apiId_ = 0;
    std::string apiHash_;
    std::string databasePath_;
};

} // namespace tdlib
