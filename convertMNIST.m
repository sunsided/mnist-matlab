function [ dataset ] = convertMNIST( image_file, label_file )
%CONVERTMNIST Converts the original MNIST dataset into MATLAB format.

    if exist('image_file', 'var') && exist('label_file', 'var')
        
        ifid = fopen(image_file, 'rb');
        if ifid == -1
            error('CMNIST:InputFileNotFound', ['No such file: ' image_file])
        end
        ic = onCleanup(@() fclose(ifid));
        
        lfid = fopen(label_file, 'rb');
        if lfid == -1
            error('CMNIST:InputFileNotFound', ['No such file: ' label_file])
        end
        lc = onCleanup(@() fclose(lfid));
        
        images = load_images(image_file, ifid);
        num_images = size(images, 3);
        width = size(images, 2);
        height = size(images, 1);
        
        labels = load_labels(label_file, lfid, num_images);
                
        dataset = struct('count', num_images, ...
                         'width', width, 'height', height, ...
                         'images', images, ...
                         'labels', labels);
        return
        
    end

    training = load_set('train');
    test     = load_set('t10k');

    save('mnist.mat', 'training', 'test');
    
    function [set] = load_set(set_name)
        
        original_path     = 'original/';
        uncompressed_path = '.uncompressed/';

        set_image_file = [set_name '-images-idx3-ubyte'];
        set_label_file = [set_name '-labels-idx1-ubyte'];

        original_image_file = [original_path set_image_file '.gz'];
        original_label_file = [original_path set_label_file '.gz'];

        disp(['Unzipping ' original_image_file ' ...']);
        gunzip(original_image_file, uncompressed_path);

        disp(['Unzipping ' original_label_file ' ...']);
        gunzip(original_label_file, uncompressed_path);

        set = convertMNIST([uncompressed_path set_image_file], [uncompressed_path set_label_file]);
        
    end
    
    function [images] = load_images(image_file, ifid)
        
        % image magic number is 2051, stored as big-endian
        magic_number = fread(ifid, 1, 'int32', 0, 'ieee-be');      
        if magic_number ~= 2051
            error('CMNIST:InvalidFile', ['Invalid file header in: ' image_file])
        end

        image_count  = fread(ifid, 1, 'int32', 0, 'ieee-be');
        rows_count   = fread(ifid, 1, 'int32', 0, 'ieee-be');
        column_count = fread(ifid, 1, 'int32', 0, 'ieee-be');

        images = fread(ifid, inf, 'unsigned char');
        if numel(images) ~= (image_count*rows_count*column_count)
            error('CMNIST:InvalidFile', ['Invalid data header in: ' image_file])
        end
        
        images = reshape(images, column_count, rows_count, image_count);
        images = permute(images, [2 1 3]);
        
        % scale to 0..1
        images = double(images) / 255;
        
    end

    function [labels] = load_labels(label_file, lfid, image_count)
        
        % label magic number is 2049, stored as big-endian
        magic_number = fread(lfid, 1, 'int32', 0, 'ieee-be');      
        if magic_number ~= 2049
            error('CMNIST:InvalidFile', ['Invalid file header in: ' label_file])
        end

        label_count  = fread(lfid, 1, 'int32', 0, 'ieee-be');
        if image_count ~= label_count
            error('CMNIST:InvalidFile', ['Label count mismatch in: ' label_file])
        end
        
        labels = fread(lfid, inf, 'unsigned char');
        if numel(labels) ~= label_count
            error('CMNIST:InvalidFile', ['Invalid data header in: ' label_file])
        end
        
        labels = double(labels);
        
    end
    
end

