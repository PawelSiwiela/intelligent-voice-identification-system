function reportProgress(current, total, start_time)
% Raportuje postęp Grid Search
progress_percent = (current / total) * 100;
elapsed_time = toc(start_time);
avg_time_per_combo = elapsed_time / current;
remaining_time = avg_time_per_combo * (total - current);

logInfo('📈 Postęp: %.1f%% (%d/%d) | ⏱️ %.1fs | 🕐 Pozostało: %.1fs', ...
    progress_percent, current, total, elapsed_time, remaining_time);
end