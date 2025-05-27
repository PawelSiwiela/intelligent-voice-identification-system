function merged_config = mergeConfigs(default_config, custom_config)
% =========================================================================
% ŁĄCZENIE KONFIGURACJI DOMYŚLNEJ Z CUSTOMOWĄ
% =========================================================================

logDebug('🔧 Łączenie konfiguracji...');

merged_config = default_config;

if ~isempty(custom_config) && isstruct(custom_config)
    custom_fields = fieldnames(custom_config);
    
    for i = 1:length(custom_fields)
        field_name = custom_fields{i};
        merged_config.(field_name) = custom_config.(field_name);
        logDebug('   🔄 Zaktualizowano: %s', field_name);
    end
    
    logDebug('✅ Połączono %d customowych pól', length(custom_fields));
else
    logDebug('ℹ️ Użyto domyślnej konfiguracji');
end

end