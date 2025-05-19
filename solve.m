%% File Info.

%{

    solve.m
    -------
    This code solves the model.

%}

%% Solve class.

classdef solve
    methods(Static)
        %% Solve the model using BI. 
        
        function sol = lc(par)            
            %% Structure array for model solution.
            
            sol = struct();
            
            %% Model parameters, grids and functions.

            J = par.J; % Number of occupations.
            w_j = par.w_j; % Wage rates.

            elen = par.elen; % Number of income shocks.
            eshock = par.eshock; % Talent.
            prob_eshock = par.prob_eshock; % Distribution.

            T = par.T; % Last period of life.
            beta = par.beta; % Discount factor.

            %% Backward induction.
            
            w1 = nan(T,J,elen); % Container for overall value function.
            v1_stay = nan(T,J,elen); % Container for V_stay.
            v1_switch = nan(T,J,elen); % Container for V_switch.
            c1_stay = nan(T,J,elen); % Container for c_stay.
            c1_switch = nan(T,J,elen); % Container for c_switch.
            o1 = nan(T,J,elen); % Occupational choice.
            d1 = nan(T,J,elen); % Discrete choice.

            fprintf('------------Solving from the Last Period of Life.------------\n\n')
            
            for a = 1:T % Start in the last period and iterate backward.
                
                % Solve the conditional value functions.
                for j = 1:J % Occupation loop.

                        % Next-period value function.
                        if T-a+1 == T % Last period of life.
                            EV = 0; % The next-period value function is zero when dead.
                        else
                            EV = prob_eshock(j,:)*squeeze(w1(T-a+2,j,:));
                        end

                        for e = 1:elen % Human capital shock loop.
                            
                            % The stayer's decision problem.
                            ystay = w_j(j);
                            c1_stay(T-a+1,j,e) = model.tax_fun(ystay,par);
                            v1_stay(T-a+1,j,e) = model.utility(c1_stay(T-a+1,j,e),eshock(j,e),par) + beta*EV;

                            % The switcher's decision problem.
                            yswitch = w_j(j)*model.cost(T-a+1,par);
                            c1_switch(T-a+1,j,e) = model.tax_fun(yswitch,par);
                            v1_switch(T-a+1,j,e) = model.utility(c1_switch(T-a+1,j,e),eshock(j,e),par) + beta*EV;

                        end

                    % Take expectations over epsilon and theta when switching.
                    v1_switch(T-a+1,j,:) = prob_eshock(j,:)*squeeze(v1_switch(T-a+1,j,:));

                end

                for j = 1:J

                    % Maximum over value functions.
                    if j == 1 % Safe occupation.
                            for e = 1:elen % Human capital shock loop.

                                if (v1_stay(T-a+1,1,e) >= v1_switch(T-a+1,2,e)) && (v1_stay(T-a+1,1,e) >= v1_switch(T-a+1,3,e)) % Stay in safe.
                                    d1(T-a+1,j,e) = 1;
                                    o1(T-a+1,j,e) = 1;
                                    w1(T-a+1,j,e) = v1_stay(T-a+1,1,e);
                                elseif v1_switch(T-a+1,3,e) < v1_switch(T-a+1,2,e) % Switch to medium.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 2;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,2,e);
                                else% Switch to risky.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 3;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,3,e);
                                end

                            end
                    elseif j == 2 % Middle occupation.
                            for e = 1:elen % Human capital shock loop.

                                if (v1_stay(T-a+1,2,e) >= v1_switch(T-a+1,1,e)) && (v1_stay(T-a+1,2,e) >= v1_switch(T-a+1,3,e)) % Stay in medium.
                                    d1(T-a+1,j,e) = 1;
                                    o1(T-a+1,j,e) = 2;
                                    w1(T-a+1,j,e) = v1_stay(T-a+1,2,e);
                                elseif v1_switch(T-a+1,3,e) < v1_switch(T-a+1,1,e) % Switch to safe.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 1;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,1,e);
                                else % Switch to risky.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 3;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,3,e);
                                end

                            end
                    elseif j == 3 % Risky occupation.
                            for e = 1:elen % Human capital shock loop.

                                if (v1_stay(T-a+1,3,e) >= v1_switch(T-a+1,1,e)) && (v1_stay(T-a+1,3,e) >= v1_switch(T-a+1,2,e)) % Stay in risky.
                                    d1(T-a+1,j,e) = 1;
                                    o1(T-a+1,j,e) = 3;
                                    w1(T-a+1,j,e) = v1_stay(T-a+1,3,e);
                                elseif v1_switch(T-a+1,2,e) < v1_switch(T-a+1,1,e) % Switch to safe.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 1;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,1,e);
                                else % Switch to medium.
                                    d1(T-a+1,j,e) = 2;
                                    o1(T-a+1,j,e) = 2;
                                    w1(T-a+1,j,e) = v1_switch(T-a+1,2,e);
                                end

                            end
                    end

                end

                % Print counter.
                if mod(T-a+1,5) == 0
                    fprintf('Age: %d.\n',T-a+1)
                end

            end
            
            fprintf('------------Life Cycle Problem Solved.------------\n')
            
            %% Macro variables, value, and policy functions.
            
            sol.w = w1; % Overall value function.
            sol.v_stay = v1_stay; % Value function when staying.
            sol.v_switch = v1_switch; % Value function when switching.
            sol.c_stay = c1_stay; % Consumption policy function when staying.
            sol.c_switch = c1_switch; % Consumption policy function when switching.
            sol.o = o1; % Occupational choice policy function.
            sol.d = d1; % Discrete choice policy function.
            
        end
        
    end
end