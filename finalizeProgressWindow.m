function finalizeProgressWindow(h_main, total_samples, num_samples, successful_loads, failed_loads)
% Finalizuje okno postępu
updateProgress(h_main, total_samples, total_samples, ...
    'Zakończono!', num_samples, num_samples, successful_loads, failed_loads);

set(h_main, 'Name', '✅ Przetwarzanie Zakończone');
pause(1.5);
close(h_main);
end