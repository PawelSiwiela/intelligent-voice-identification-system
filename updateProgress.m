function stop_requested = updateProgress(h_fig, current, total, category_name, sample_num, max_samples, successful, failed)
stop_requested = false;

if ~isvalid(h_fig)
    stop_requested = true;
    return;
end

if isfield(h_fig.UserData, 'stop_requested') && h_fig.UserData.stop_requested
    stop_requested = true;
    return;
end

percentage = (current / total) * 100;
bar_width = round(510 * current / total);

set(h_fig.UserData.progress_bar, 'Position', [20, 170, bar_width, 20]);
set(h_fig.UserData.percent_text, 'String', sprintf('%.1f%%', percentage));

status_str = sprintf('🎯 %s | Próbka %d/%d', category_name, sample_num, max_samples);
set(h_fig.UserData.status_text, 'String', status_str);

stats_str = sprintf('✅ Udane: %d | ❌ Nieudane: %d', successful, failed);
set(h_fig.UserData.stats_text, 'String', stats_str);

elapsed = toc(h_fig.UserData.start_time);
if current > 0
    estimated_total = elapsed * total / current;
    remaining = estimated_total - elapsed;
    time_str = sprintf('⏱️ Czas: %.1fs | Pozostało: ~%.1fs', elapsed, remaining);
else
    time_str = sprintf('⏱️ Czas: %.1fs', elapsed);
end
set(h_fig.UserData.time_text, 'String', time_str);

drawnow limitrate;
end