from flask import Blueprint, request, jsonify, current_app
import oracledb 

api_blueprint = Blueprint('api', __name__)

@api_blueprint.route('/update_faccao_nome', methods=['POST'])
def update_faccao_nome():
    data = request.get_json()
    old_name = data.get('old_name')
    new_name = data.get('new_name')

    if not old_name or not new_name:
        return jsonify({'error': 'Both old_name and new_name are required'}), 400

    try:
        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_lider.update_faccao_nome', [old_name, new_name])

        current_app.oracle_connection.commit()
        cursor.close()

        return jsonify({'message': 'Faction name updated successfully'}), 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500


@api_blueprint.route('/indica_lider', methods=['POST'])
def indica_lider():
    data = request.get_json()
    novo_lider = data.get('novo_lider')
    nome_faccao = data.get('nome_faccao')

    if not novo_lider or not nome_faccao:
        return jsonify({'error': 'Both novo_lider and nome_faccao are required'}), 400

    try:
        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_lider.indica_lider', [novo_lider, nome_faccao])

        current_app.oracle_connection.commit()
        cursor.close()

        return jsonify({'message': 'Leader indicated successfully'}), 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/insereParticipa', methods=['POST'])
def insereParticipa():
    data = request.get_json()
    especie = data.get('especie')
    comunidade = data.get('comunidade')
    faccao = data.get('faccao')

    try:
        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_lider.INSERE_PARTICIPA', [especie,comunidade,faccao])

        current_app.oracle_connection.commit()
        cursor.close()

        return jsonify({'message': 'Insert Nice'}), 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/removeNacao', methods=['POST'])
def removeNacao():
    data = request.get_json()
    lider = data.get('lider')
    nacao = data.get('nacao')

    try:
        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_lider.remove_faccao_nacao', [lider,nacao])

        current_app.oracle_connection.commit()
        cursor.close()

        return jsonify({'message': 'Faction Removed'}), 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500


# Login


@api_blueprint.route('/login', methods = ['GET'])
def login():
    try:
        user = request.args.get("user")
        senha = request.args.get("senha")

        cursor = current_app.oracle_connection.cursor()
        query = """
        SELECT L.CPI,L.nome, L.Cargo, L.Nacao,F.Nome
        FROM app_users AP 
        JOIN Lider L ON AP.idLider = L.CPI 
        LEFT JOIN Faccao F on F.lider = L.CPI
        WHERE AP.idlider = :idlider 
        AND password = app_user_security.get_hash(:password)
        """

        # Execute the query with parameters
        cursor.execute(query, idlider=user, password=senha)

        rows = cursor.fetchall()
        
        if len(rows) != 1:
            cursor.close()
            return jsonify(rows), 403

        cursor.close()
        return jsonify(rows[0]), 200


    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500


# Comandante

@api_blueprint.route('/sairFederacao', methods = ['DELETE'])
def SairFederacao():
    try:
        nacao = request.args.get("nacao")


        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('GerenciamentoComandante.sair_federacao',[nacao])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/entrarFederacao', methods = ['POST'])
def EntrarFederacao():
    try:
        nacao = request.args.get("nacao")
        federacao = request.args.get("federacao")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('GerenciamentoComandante.entrar_federacao',[nacao, federacao])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        return jsonify({'error': str(error)}), 500 

@api_blueprint.route('/criarFederacao', methods = ['POST'])
def CriarFederacao():
    try:
        data = request.get_json()
        nacao = data.get("nacao")
        federacao = data.get("federacao")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('GerenciamentoComandante.criar_federacao_com_nacao',[federacao,nacao])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/dominarPlaneta', methods = ['POST'])
def DominanciaPlaneta():
    try:
        data = request.get_json()
        nacao = data.get("nacao")
        idPlaneta = data.get("planeta")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('GerenciamentoComandante.dominancia_planeta',[idPlaneta,nacao])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    


# Cientista
@api_blueprint.route('/estrela', methods = ['POST'])
def CriaEstrela():
    try:
        data = request.get_json()
        idPlaneta = data.get("id")
        nome = data.get("nome")
        classificacao = data.get("classificacao")
        massa = data.get("massa")
        coordX = data.get("coordX")
        coordY = data.get("coordY")
        coordZ = data.get("coordZ")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_cientista.cria_estrela',[idPlaneta,nome,classificacao,massa,coordX,coordY,coordZ])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/estrela', methods = ['PUT'])
def AtualizaEstrela():
    try:
        data = request.get_json()
        id = data.get("id")
        nome = data.get("nome")
        classificacao = data.get("classificacao")
        massa = data.get("massa")
        coordX = data.get("coordX")
        coordY = data.get("coordY")
        coordZ = data.get("coordZ")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_cientista.atualiza_estrela',[id,nome,classificacao,massa,coordX,coordY,coordZ])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/estrela', methods = ['DELETE'])
def DeleteEstrela():
    try:
        data = request.get_json()
        id = data.get("id")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_cientista.remove_estrela',[id])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/estrela', methods=['GET'])
def PegarEstrela():
    try:
        nome = request.args.get("nome")
        id = request.args.get("id")

        cursor = current_app.oracle_connection.cursor()

        out_cursor = cursor.var(oracledb.CURSOR)

        if id:
            cursor.callproc('gerenciamento_cientista.read_estrela_id', [id, out_cursor])
        elif nome:
            cursor.callproc('gerenciamento_cientista.read_estrela_nome', [nome, out_cursor])
        
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchone()
        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "Estrela não encontrada"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/sistema', methods = ['POST'])
def CriaSistema():
    try:
        data = request.get_json()
        idEstrela = data.get("id")
        nome = data.get("nome")

        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_cientista.cria_sistema',[idEstrela,nome])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/orbita', methods = ['POST'])
def CriaOrbita():
    try:
        data = request.get_json()
        orbitante = data.get("idOrbitante")
        orbitada = data.get("idOrbitada")
        distMin = data.get("distMin")
        distMax = data.get("distMax")
        periodoOrbita = data.get("periodoOrbita")
        
        cursor = current_app.oracle_connection.cursor()

        cursor.callproc('gerenciamento_cientista.cria_orbita_estrela',[orbitante,orbitada,distMin,distMax,periodoOrbita])

        cursor.close()

        return '', 200

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

# Relatórios Lider

@api_blueprint.route('/relatoriosLiderPlaneta', methods = ['GET'])
def RelatorioLiderPlaneta():
    try:        
        faccao = request.args.get("faccao")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_lider.comunidades_faccao_planeta',[faccao,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/relatoriosLiderEspecie', methods = ['GET'])
def RelatorioLiderEspecie():
    try:        
        faccao = request.args.get("faccao")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_lider.comunidades_faccao_especie',[faccao,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500
    
@api_blueprint.route('/relatoriosLiderSistema', methods = ['GET'])
def RelatorioLiderSistema():
    try:        
        faccao = request.args.get("faccao")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_lider.comunidades_faccao_sistema',[faccao,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosLidernacao', methods = ['GET'])
def RelatorioLiderNacao():
    try:        
        faccao = request.args.get("faccao")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_lider.comunidades_faccao_sistema',[faccao,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

# Relatórios Comandante

@api_blueprint.route('/relatoriosComandantePlanetas', methods = ['GET'])
def RelatorioComandantePlanetas():
    try:        

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)
        out_cursor2 = cursor.var(oracledb.CURSOR)

        cursor.callproc('RELATORIO_COMANDANTE.info_planetas',[out_cursor, out_cursor2])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        result_cursor = out_cursor2.getvalue()
        result2 = result_cursor.fetchall()

        response = [result, result2]

        cursor.close()

        if response:
            return jsonify(response), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosplanetasPreocupantes', methods = ['GET'])
def RelatoriosplanetasPreocupantes():
    try:        
        lider = request.args.get("lider")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('RELATORIO_COMANDANTE.planetas_preocupantes',[lider,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosplanetasPotenciais', methods = ['GET'])
def RelatoriosplanetasPotenciais():
    try:        
        maxDist = request.args.get("mDist")
        nacao = request.args.get("nacao")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('RELATORIO_COMANDANTE.planetas_potencial_expansao',[maxDist,nacao,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500


# Relatórios Cientista

@api_blueprint.route('/relatorioCientista', methods = ['GET'])
def ReportCientista():
    try:
        
        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_cientista.CIENTISTA_RELATORIO_PLANETA',[out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.callproc('relatorio_cientista.CIENTISTA_RELATORIO_ESTRELA',[out_cursor])
        result_cursor2 = out_cursor.getvalue()
        result2 = result_cursor2.fetchall()

        cursor.callproc('relatorio_cientista.CIENTISTA_RELATORIO_SISTEMA',[out_cursor])
        result_cursor3 = out_cursor.getvalue()
        result3 = result_cursor3.fetchall()

        response = [result,result2,result3]

        cursor.close()

        if response:
            return jsonify(response), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/buscarDist', methods = ['GET'])
def BuscarDistancia():
    try:        
        estrelaRef = request.args.get("estrela")
        minDist = request.args.get("minDist")
        maxDist = request.args.get("maxDist")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_cientista.buscar_estrelas_por_distancia',[estrelaRef,minDist,maxDist,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

# Relatórios Oficial
@api_blueprint.route('/relatoriosoficiaishabitantes', methods = ['GET'])
def Relatoriosoficiaishabitantes():
    try:        
        lider = request.args.get("lider")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_oficial.habitantes_por_faccao',[lider,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosoficiaisEspecies', methods = ['GET'])
def RelatoriosoficiaisEspecies():
    try:        
        lider = request.args.get("lider")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_oficial.habitantes_por_especie',[lider,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosoficiaisplaneta', methods = ['GET'])
def Relatoriosoficiaisplaneta():
    try:        
        lider = request.args.get("lider")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_oficial.habitantes_por_planeta',[lider,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

@api_blueprint.route('/relatoriosoficiaissistema', methods = ['GET'])
def Relatoriosoficiaissistema():
    try:        
        lider = request.args.get("lider")

        cursor = current_app.oracle_connection.cursor()
        out_cursor = cursor.var(oracledb.CURSOR)

        cursor.callproc('relatorio_oficial.habitantes_por_sistema',[lider,out_cursor])
        result_cursor = out_cursor.getvalue()
        result = result_cursor.fetchall()

        cursor.close()

        if result:
            return jsonify(result), 200
        else:
            return jsonify({"error": "reports não encontrados"}), 404

    except oracledb.DatabaseError as e:
        error, = e.args
        print(error)
        return jsonify({'error': str(error)}), 500

