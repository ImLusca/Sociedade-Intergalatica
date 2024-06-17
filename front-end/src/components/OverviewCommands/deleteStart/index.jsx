import React, { useState } from 'react';
import Styles from "./deleteStar.module.css";
import axios from "axios";

const DeleteStar = () => {
    const [idEstrela, setIdEstrela] = useState("");

    const ClearFields = () => {
        setIdEstrela("");
    };

    const handleDeleteStar = async () => {
        const jsonBody = {
            id: idEstrela
        };

        try {
            const response = await axios.delete(`http://127.0.0.1:5000/estrela`, { data: jsonBody });
            if (response.status === 200) {
                alert('Estrela deletada com sucesso');
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
            <h3>Deletar Estrela</h3>
            <div className={Styles.container}>
                <input type="text" value={idEstrela} placeholder='ID da Estrela' onChange={(e) => setIdEstrela(e.target.value)} />
                <button onClick={handleDeleteStar}>Deletar Estrela</button>
            </div>
        </>
    );
};

export default DeleteStar;
