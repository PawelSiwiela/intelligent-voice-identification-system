% Inicjalizacja środowiska
close all; clear all; clc;

% Dodanie ścieżek projektu
addpath(genpath('new_src'));

% Uruchomienie testu na rzeczywistych danych
results = testBoxplots();