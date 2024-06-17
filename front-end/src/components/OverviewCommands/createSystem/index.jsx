import React, { useState } from 'react';
import Styles from "./createSystem.module.css";
import axios from "axios";

const CreateSistema = () => {
    const [idEstrela, setIdEstrela] = useState("");
    const [nome, setNome] = useState("");

    const ClearFields = () => {
        setIdEstrela("");
        setNome("");
    };

    const handleCreateSistema = async () => {
        const jsonBody = {
            id: idEstrela,
            nome: nome
        };

        try {
            const response = await axios.post(`http://127.0.0.1:5000/sistema`, jsonBody);
            if (response.status === 200) {
                alert('Sistema criado com sucesso');
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
            <h3>Criar Sistema</h3>
            <div className={Styles.container}>
                <input type="text" value={idEstrela} placeholder='ID da Estrela' onChange={(e) => setIdEstrela(e.target.value)} />
                <input type="text" value={nome} placeholder='Nome do Sistema' onChange={(e) => setNome(e.target.value)} />
                <button onClick={handleCreateSistema}>Criar Sistema</button>
            </div>
        </>
    );
};

export default CreateSistema;
