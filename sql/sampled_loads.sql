SELECT 
    id,
    timestamp,
    webHost,
    wiki,
    event_experimentGroup,
    event_experimentId,
    event_loadedModulesCount,
    event_loadedModulesSize,
    event_mobileMode,
    event_moduleLoadingTime,
    event_moduleStoreEnabled,
    event_moduleStoreExpired,
    event_moduleStoreHits,
    event_moduleStoreMisses,
    event_loadIndex,
    simple_platform,
    simple_browser,
    max_loadIndex
FROM halfak.ms_indexed_load loads
INNER JOIN halfak.ms_load_simple_ua USING (id)
INNER JOIN halfak.ms_user_max_index USING (event_experimentId);
