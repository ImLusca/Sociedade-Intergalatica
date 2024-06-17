import React, { useState } from 'react';
import Styles from "./createStar.module.css"
import axios from "axios"

const CreateStar = () => {
    const [idPlaneta, setIdPlaneta] = useState("");
    const [nome, setNome] = useState("");
    const [classificacao, setClassificacao] = useState("");
    const [massa, setMassa] = useState("");
    const [coordX, setCoordX] = useState("");
    const [coordY, setCoordY] = useState("");
    const [coordZ, setCoordZ] = useState("");

    const ClearFields= ()=>{
        setIdPlaneta("");
        setNome("");
        setClassificacao("");
        setMassa("");
        setCoordX("");
        setCoordY("");
        setCoordZ("");
    }

    const handleCreateStar = async () => {
        const jsonBody = {
            id: idPlaneta,
            nome: nome,
            classificacao: classificacao,
            massa: massa,
            coordX: coordX,
            coordY: coordY,
            coordZ: coordZ
        };

        try {
            const response = await axios.post(`http://127.0.0.1:5000/estrela`, jsonBody);
            if (response.status === 200) {
                alert('Estrela criada com sucesso');
                ClearFields();
            } else {
                alert(response.data.error);
            }
        } catch (error) {
            alert(`Erro: ${error.response?.data?.error || error.message}`);
        }
    };

    const handleUpdateStar = async () => {
        const jsonBody = {
            id: idPlaneta,
            nome: nome,
            classificacao: classificacao,
            massa: massa,
            coordX: coordX,
            coordY: coordY,
            coordZ: coordZ
        };

        try {
            const response = await axios.put(`http://127.0.0.1:5000/estrela`, jsonBody);
            if (response.status === 200) {
                alert('Estrela Atualizada com sucesso');
                ClearFields();
            } else {
                alert(response.data.error);
            }
        } catch (error) {
            alert(`Erro: ${error.response?.data?.error || error.message}`);
        }
    };

    return (
        <>
            <h3>Criar / Atualizar Estrela</h3>
            <div className={Styles.container}>
                <input type="text" value={idPlaneta} placeholder='ID da Estrela' onChange={(e) => setIdPlaneta(e.target.value)} />
                <input type="text" value={nome} placeholder='Nome da Estrela' onChange={(e) => setNome(e.target.value)} />
                <input type="text" value={classificacao} placeholder='Classificação' onChange={(e) => setClassificacao(e.target.value)} />
                <input type="text" value={massa} placeholder='Massa' onChange={(e) => setMassa(e.target.value)} />
                <input type="text" value={coordX} placeholder='Coordenada X' onChange={(e) => setCoordX(e.target.value)} />
                <input type="text" value={coordY} placeholder='Coordenada Y' onChange={(e) => setCoordY(e.target.value)} />
                <input type="text" value={coordZ} placeholder='Coordenada Z' onChange={(e) => setCoordZ(e.target.value)} />
                <button onClick={handleCreateStar}>Criar Estrela</button>
                <button onClick={handleUpdateStar}>Atualizar Estrela</button>
            </div>
        </>
    );
};

export default CreateStar;
