classdef Utils
    methods (Static)
        function [uv] = unitvect(vect)
            % unitvect - find unit vector of provided vector
            uv = vect ./ vecnorm(vect,2,2);
        end
        function [state] = isValidTarget(target, robots)
            % isvalidtarget - true if target within robot workspace

            P = target;
            P1 = robots(1,:);
            P2 = robots(2,:);
            P3 = robots(3,:);

            s = det([P1-P2;P3-P1]);
            state = s*det([P3-P;P2-P3])>=0 & s*det([P1-P;P3-P1])>=0 & s*det([P2-P;P1-P2])>=0;
        end

        function [targets] = generate_training_targets(ntargets, robots)
            % generate_training_targets - create set of random points to
            % drive the object to
            % size of targets must be ntargets x 2

            n1 = 2*robots(3,1)*(rand(ntargets,1)-0.5); % generate random x positions in range [-0.433 0.433]
            n2 = 2*robots(2,2)*(rand(ntargets,1)-0.5); % generate random y postions in range [0 0.5]
            targets = [n1 n2];

            for i = 1:size(targets,1)
                target = targets(i,:);
                while ~Utils.isValidTarget(target,robots)
                    targets(i,:) = [robots(3,1)*(rand(1,1)-0.5) robots(2,2)*rand(1,1)];
                    target = targets(i,:);
                end
            end
        end

        function [state] = isValidCableLength(robots, obj)
            % isValidCableLength - verify Hooke's law for object position
            %   - robots - array of robot positions
            %   - object - vector of object coordinates
            %   - dist - distance between robots
            %       - currently hard coded here to not pass so many variables

            state = true;
            dist = 0.866;
            max_length = 2;
            min_length = 1;
            spooled = max_length - dist;

            cable_lengths = Utils.get_cable_lengths(robots, obj) + spooled;

            if max(cable_lengths) > max_length || min(cable_lengths) < min_length
                % error('Invalid Cable Length')
                state = false;
                % need to make an "event function" for the ode that will
                % stop it early. should improve simulation time & will
                % better penalize simulations that break early
            end
        end

        function [cable_lengths] = get_cable_lengths(robots, obj)
            cable_coords = robots - obj;
            cable_lengths = sqrt(sum(cable_coords.^2,2));
        end
    end
end