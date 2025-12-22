import numpy as np
class PRBS:
    def __init__(self,prbs_taps, parallelism, seed_taps):
        self.__prbs_poly = self.__Taps2Poly(prbs_taps)
        self.__k = parallelism
        self.__seed = self.__Taps2Poly(seed_taps)
        self.__degree = len(self.__prbs_poly) - 1 if self.__prbs_poly else -1
        self.__sample = self.__sample_generator()
    
    @staticmethod
    def __Taps2Poly(taps):
        return [1 if i in taps else 0 for i in range(max(taps),0,-1)] + [1]

    @classmethod
    def create(cls,prbs_taps, parallelism, seed_taps):
        poly = cls.__Taps2Poly(prbs_taps)
        seed = cls.__Taps2Poly(seed_taps)
        n = len(poly) - 1 if poly else -1
        k = parallelism
        if(n != len(seed)):
            print("Invalid configuration.\nPlease make sure that the length of the seed matches the length of the PRBS - 1.\nFor example: \nprbs_taps = [3,1]\nseed_taps = [2,1]")
            return None
        elif(not (np.gcd(k,2**n - 1) == 1 and (2**n - 1) > k)):
            print("Invalid configuration.\nPlease make sure that the Maximum common divider between the parallelism and the PRBS poly is 1")
            return None
        else:
            return cls(prbs_taps, parallelism, seed_taps)
        
    ###############################################################################################################
    # Public
    ###############################################################################################################
    def get_sample(self):
        return next(self.__sample)

    ########################################################################################################
    # Private
    ########################################################################################################
    def __matrix_generetor(self):
        """Genera la matriz de fibonacci de la PRBS"""
        n = self.__degree
        poly = self.__prbs_poly
        M = np.diag([1 for _ in range(n-1)],1)
        M[-1::] = poly[0:n]
        return M

    def __connection_Matrix(self):
        """Calcula la matriz de conexion de los coeficientes de estado."""
        n = self.__degree #Orden de la PRBS
        k = self.__k
        n_matrix = int(np.ceil(k/n)) #Numero de matrices
        n_filas =  n - k%n if k%n else 0 #Numero de filas sobrantes

        M_org = self.__matrix_generetor() #Genera la matriz de Fibonacci

        #Calculo las matrices de salto
        M_aux = []
        while k > 0:
            M = (np.matrix(M_org)**k)%2 # Nos mantenemos en GF(2)
            k -= n
            M_aux.append(M)

        #Acomodo las matrices
        M_aux = np.array(M_aux)[np.insert(np.arange(n_matrix)[1:][::-1],0,0)]

        #Quito las filas sobrantes y genero una unica matriz de conexiones
        connection = np.vstack(M_aux[0])
        if n_matrix > 1:
            connection = np.vstack((M_aux[0],M_aux[1][n_filas::]))
        if n_matrix >= 2:
            for i in np.arange(2,n_matrix):
                connection = np.vstack((connection,M_aux[i]))
        return connection
    
    def __sample_generator(self):
        """Realiza las conexiones y entrega el valor correspondiente de la PRBS para el paralelismo k."""
        connections = self.__connection_Matrix().tolist()
        n = self.__degree
        k = self.__k
        seed = self.__seed
        state = seed[::-1]
        add = []
        for i in range(k-n):
            add.append(int(np.bitwise_xor.reduce(np.bitwise_and(state,connections[n+i]))))
        out = state + add

        while(1):
            yield out
            new_state = []
            extra_lines = []
            for i in range(k if k > n else n):
                if i < n:
                    new_state.append(int(np.bitwise_xor.reduce(np.bitwise_and(state,connections[i]))))
                else:
                    extra_lines.append(int(np.bitwise_xor.reduce(np.bitwise_and(new_state,connections[i]))))
            out = new_state+extra_lines
            state = new_state