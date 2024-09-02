from fabric import Connection
import subprocess
import os

class ServerDeploy:
    def __init__(self):

        self.host = '194.87.210.193'
        self.user = 'root'
        self.password = 'mjn6ckHLOG'

        self.connection = Connection(
            self.host, 
            user=self.user, 
            connect_kwargs={
                'password': self.password
        })

        self.local_folder_path = 'C:\\Users\\gomol\\FlutterProjects\\water_reminder\\water_reminder\\build\\web\\'
        self.server_folder_path = '/var/www/flutter_server/html'

    def compile_web_app(self):
        print('[I] Compiling flutter web project...')

        result = subprocess.run(['cd', 'C:\\Users\\gomol\\FlutterProjects\\water_reminder\\water_reminder'], shell=True)
        result = subprocess.run(['flutter', 'build', 'web'], shell=True)

        print('[I] Build is finished...')

    def remove_directory(self):
        print('[III] Clear working directory..')
        output = self.connection.run(f'test -d {self.server_folder_path} && echo "Found" || echo "Not Found" ', hide=True)
        output = output.stdout[:-1]
        if output == 'Found':
            self.connection.run(f'sudo rm -r {self.server_folder_path}', hide=True)
        print('Succsesfull clear!')

    def create_directory(self, path):  
        output = self.connection.run(f'test -d {path} && echo "Found" || echo "Not Found" ', hide=True)
        output = output.stdout[:-1]
        if output == 'Not Found':
            print(f'[IV] Making new directory {path}')
            self.connection.run(f'sudo mkdir {path}', hide=True)
            print('[IV] Succesfull making!')
        

    def deploy(self):
        print('Deploy starts...')
        self.compile_web_app()
        
        print('[II] SSH connecting to server...')
        print('[II] Succsesfull connect!')
        self.remove_directory()
        self.create_directory(self.server_folder_path)

        _files = []
        for root, dirs, files in os.walk(self.local_folder_path):
            for file in files:
                _files.append(os.path.join(root, file))

        current_path = ''
        for _file in _files:
            short_path = _file.replace(self.local_folder_path, '')
            while short_path.count('\\') > 0:
                item = short_path.split('\\')[0]
                current_path += f'{item}/'
                self.create_directory(self.server_folder_path + '/' + current_path)
                short_path = short_path.replace(item + '\\', '')
            print(f'[V] Transfer file {_file}')
            self.connection.put(_file, self.server_folder_path + '/' + current_path)
            current_path = ''

        print('Restarting server...')
        self.connection.run('sudo systemctl restart nginx')
        print('Server restarted!')
        print('Deploy is finished!')


if __name__ == "__main__":
    connection = ServerDeploy()
    connection.deploy()

