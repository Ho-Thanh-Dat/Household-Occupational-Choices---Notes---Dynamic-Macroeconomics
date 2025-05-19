%% File Info.

%{

    my_graph.m
    ----------
    This code plots the value and policy functions and the time path of the variables.

%}

%% Graph class.

classdef my_graph
    methods(Static)
        %% Plot value and policy functions.
        
        function [] = plot_policy(par,sol)
            %% Plot discrete choice policy function.

            age_grid = linspace(1,par.T,par.T);
          
            close all
                     
            figure(1)
            h=heatmap(par.eshock(1,:)',age_grid',squeeze(sol.d(:,1,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Stay vs. Switching by Age in Safe Occupation';
                 
            figure(2)
            h=heatmap(par.eshock(2,:)',age_grid',squeeze(sol.d(:,2,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Stay vs. Switching by Age in Medium Occupation';
               
            figure(3)
            h=heatmap(par.eshock(3,:)',age_grid',squeeze(sol.d(:,3,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Stay vs. Switching by Age in Risky Occupation';

            %% Plot occupational choice choice policy function.

            figure(4)
            h=heatmap(par.eshock(1,:)',age_grid',squeeze(sol.o(:,1,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Occupational Choice by Age in Safe Occupation';
                 
            figure(5)
            h=heatmap(par.eshock(2,:)',age_grid',squeeze(sol.o(:,2,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Occupational Choice by Age in Medium Occupation';
               
            figure(6)
            h=heatmap(par.eshock(3,:)',age_grid',squeeze(sol.o(:,3,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Occupational Choice by Age in Risky Occupation';
            
            %% Plot consumption policy function.

            figure(7)
            h=heatmap(par.eshock(1,:)',age_grid',squeeze(sol.c_stay(:,1,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Stayers in Safe Occupation';
                 
            figure(8)
            h=heatmap(par.eshock(2,:)',age_grid',squeeze(sol.c_stay(:,2,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Stayers in Medium Occupation';
                 
            figure(9)
            h=heatmap(par.eshock(3,:)',age_grid',squeeze(sol.c_stay(:,3,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Stayers in Risky Occupation';
                 
            figure(10)
            h=heatmap(par.eshock(1,:)',age_grid',squeeze(sol.c_switch(:,1,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Switchers to Safe Occupation';
                  
            figure(11)
            h=heatmap(par.eshock(2,:)',age_grid',squeeze(sol.c_switch(:,2,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Switchers to Medium Occupation';
                 
            figure(12)
            h=heatmap(par.eshock(3,:)',age_grid',squeeze(sol.c_switch(:,3,:)));

            h.XLabel = '\epsilon_j';
            h.YLabel = 'Age';
            h.Title = 'Consumption by Age: Switchers to Risky Occupation';

        end
        
    end
end